// srv/server.js
const cds = require('@sap/cds')

// Configure authentication
cds.on('bootstrap', app => {
  const cors = require('cors')
  
  // CORS configuration for local development and production
  const corsOptions = {
    origin: function (origin, callback) {
      // Allow requests with no origin (like mobile apps or curl requests)
      if (!origin) return callback(null, true)
      
      // Development origins
      const allowedOrigins = [
        'http://localhost:8080',
        'http://127.0.0.1:8080',
        'http://localhost:4004',
        'http://127.0.0.1:4004'
      ]
      
      // Production: allow any HTTPS origin from the same domain
      if (origin.startsWith('https://') && origin.includes('.cfapps.')) {
        return callback(null, true)
      }
      
      if (allowedOrigins.indexOf(origin) !== -1) {
        callback(null, true)
      } else {
        callback(new Error('Not allowed by CORS'))
      }
    },
    credentials: true
  }
  
  app.use(cors(corsOptions))
  
  // Health check endpoint for Cloud Foundry
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UP', timestamp: new Date().toISOString() })
  })
})

// Service implementation
cds.on('served', () => {
  const { MaterialRequests } = cds.entities('ima')
  const catalogService = cds.services.CatalogService
  
  // Before CREATE - set default values and validate
  catalogService.before('CREATE', 'MaterialRequests', req => {
    const { data } = req
    
    // Set default status if not provided
    if (!data.status) {
      data.status = 'pendingApproval'
    }
    
    // Set default priority if not provided
    if (!data.requestPriority) {
      data.requestPriority = 'medium'
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (data.email && !emailRegex.test(data.email)) {
      req.error(400, 'Invalid email format')
    }
  })
  
  // Action implementations
  catalogService.on('approveRequest', async req => {
    const { ID, materialNumber, comments } = req.data
    
    try {
      await UPDATE(MaterialRequests)
        .set({
          status: 'pendingIMA',
          materialNumber: materialNumber,
          approverComments: comments
        })
        .where({ ID: ID })
      
      return 'Request approved successfully'
    } catch (error) {
      req.error(500, `Failed to approve request: ${error.message}`)
    }
  })
  
  catalogService.on('rejectRequest', async req => {
    const { ID, comments } = req.data
    
    try {
      await UPDATE(MaterialRequests)
        .set({
          status: 'rejected',
          approverComments: comments
        })
        .where({ ID: ID })
      
      return 'Request rejected'
    } catch (error) {
      req.error(500, `Failed to reject request: ${error.message}`)
    }
  })
  
  catalogService.on('completeRequest', async req => {
    const { ID, materialNumber } = req.data
    
    try {
      await UPDATE(MaterialRequests)
        .set({
          status: 'completedByIMA',
          materialNumber: materialNumber
        })
        .where({ ID: ID })
      
      return 'Request completed by IMA'
    } catch (error) {
      req.error(500, `Failed to complete request: ${error.message}`)
    }
  })
})

module.exports = cds.server
