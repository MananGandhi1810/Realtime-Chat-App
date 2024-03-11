const { WebSocketServer } = require('ws')
const uuid = require('uuid')
const redis = require('redis')
const express = require('express')
const { PrismaClient } = require('@prisma/client')
const jsonwebtoken = require('jsonwebtoken')

const publisher = redis.createClient()
const subscriber = publisher.duplicate()
const wss = new WebSocketServer({ port: 8080 })

const prisma = new PrismaClient()
const app = express()
app.use(express.json())

const appSecretKey = process.env.APP_SECRET_KEY || 'thisIsASecretKey'
const port = process.env.PORT || 3000

publisher.connect((address = 'redis://localhost:6379'))
subscriber.connect((address = 'redis://localhost:6379'))

wss.on('connection', function connection (ws) {
  ws.on('error', console.error)
  ws.id = uuid.v4()

  ws.on('message', function message (data) {
    data = JSON.parse(data)
    data.id = ws.id
    console.log('received: %s', data)

    if (data.type === 'join') {
      const authToken = data.token
      if (!authToken) {
        return ws.send(
          JSON.stringify({
            type: 'error',
            message: 'Unauthorized'
          })
        )
      }
      jsonwebtoken.verify(authToken, appSecretKey, async (err, user) => {
        if (err) {
          return ws.send(
            JSON.stringify({
              type: 'error',
              message: 'Unauthorized'
            })
          )
        }
        const dbUser = await prisma.user.findUnique({
          where: {
            id: user.id
          }
        })
        if (!dbUser) {
          return ws.send(
            JSON.stringify({
              type: 'error',
              message: 'Unauthorized'
            })
          )
        }
        console.log('user: ', dbUser)
        ws.user = dbUser
      })
    } else if (data.type === 'message') {
      if (!ws.user) {
        return ws.send(
          JSON.stringify({
            type: 'error',
            message: 'Unauthorized'
          })
        )
      }
      publisher.publish(
        'chat',
        JSON.stringify({
          message: data.message,
          user: ws.user
        })
      )
    }

    wss.clients.forEach(function each (client) {
      if (client !== ws) {
        client.send(JSON.stringify(data))
      }
    })
  })

  ws.on('close', function close () {
    console.log(ws.id + ' disconnected')
  })
})

function authenticate (req, res, next) {
  const authHeader = req.headers.authorization
  if (!authHeader) {
    return res.status(401).json({ message: 'Unauthorized', status: 'error' })
  }
  const token = authHeader.split(' ')[1]
  if (!token) {
    return res.status(401).json({ message: 'Unauthorized', status: 'error' })
  }
  jsonwebtoken.verify(token, appSecretKey, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Forbidden', status: 'error' })
    }
    const dbUser = prisma.user.findUnique({
      where: {
        id: user.id
      }
    })
    req.user = dbUser
    const newToken = jsonwebtoken.sign(
      { id: user.id, email: user.email, name: user.name },
      appSecretKey
    )
    req.refreshToken = newToken
    next()
  })
}

app.post('/login', async (req, res) => {
  const { email, password } = req.body
  const user = await prisma.user.findFirst({
    where: {
      email,
      password
    }
  })
  if (!user) {
    return res.status(401).json({ message: 'User not found', status: 'error' })
  }
  const token = jsonwebtoken.sign(
    { id: user.id, email: user.email, name: user.name },
    appSecretKey
  )
  res.json({
    message: 'Logged in successfully',
    status: 'success',
    token: token,
    user: {
      id: user.id,
      email: user.email,
      name: user.name
    }
  })
})

app.post('/register', async (req, res) => {
  if (!req.body) {
    return res.status(400).json({ message: 'Invalid request', status: 'error' })
  }
  const { email, password, name } = req.body
  if (!email || !password || !name) {
    return res.status(400).json({ message: 'Invalid request', status: 'error' })
  }
  const user = await prisma.user.create({
    data: {
      email,
      password,
      name
    }
  })
  const token = jsonwebtoken.sign(
    { id: user.id, email: user.email, name: user.name },
    appSecretKey
  )
  res.json({
    message: 'Registered successfully',
    status: 'success',
    token: token,
    user: {
      id: user.id,
      email: user.email,
      name: user.name
    }
  })
})

app.post('/verify_user', authenticate, async (req, res) => {
  res.json({
    message: 'User verified',
    status: 'success',
    user: req.user,
    token: req.refreshToken
  })
})

app.get('/messages', authenticate, async (req, res) => {
  const messages = await prisma.message.findMany()
  res.json(messages)
})

app.listen(port, () => {
  console.log(`Server running on port ${port}`)
})

subscriber.subscribe('chat', async function (message, channel) {
  console.log(channel, message)
  message = JSON.parse(message)
  console.log('received: %s', message)
  await prisma.message.create({
    data: {
      content: message.message,
      userId: message.user.id
    }
  })
  console.log('saved message')
})
