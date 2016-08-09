restify          = require 'restify'
shortid          = require 'shortid'
mongoose         = require 'mongoose'  
mongoose.Promise = global.Promise

port    = process.env.PORT || 3000
baseUrl = "http://localhost:#{port}"

# REST SERVER SETUP
  
server = restify.createServer( name: 'URL Shortener' )
server.use(restify.bodyParser())

# MONGOOSE SCHEMA SETUP

redirSchema = new mongoose.Schema(  
  shortUrl  : String
  url       : String
  createdAt : Date
)

Redir = mongoose.model('Redir', redirSchema)  

mongoUri = process.env.MONGOURI || 'mongodb://localhost:27017/shortio'  # 'mongodb://localhost/shortio'

# MONGOOSE AND MONGOLAB (Recommended Settings)
options =   
  server  : socketOptions: { keepAlive: 300000, connectTimeoutMS: 30000 }
  replset : socketOptions: { keepAlive: 300000, connectTimeoutMS : 30000 }

mongoose.connect(mongoUri, options)

# ROUTES

server.get( '/', restify.serveStatic(
  
  directory : 'views/'
  default   : 'index.html'

))

server.get(/\/public\/?.*/, restify.serveStatic(

  directory: __dirname

))

server.post( '/new', (req, res, next)->

  if !require('validator').isURL(req.params.url)
    res.send error : "Mistyped URL?"
    return next()

  uniqueID = shortid.generate()

  newRedir = new Redir(
    shortUrl  : "#{baseUrl}/#{uniqueID}"
    url       : req.params.url
    createdAt : new Date()
  )

  newRedir.save( (err, redir)-> res.send( if err? then err else redir ) )

  next()

)

server.get( '/:hash', (req, res, next)-> 

  query = { 'shortUrl': "#{baseUrl}/#{req.params.hash}" }

  Redir.findOne(query, (err, redir) -> 
    if err then return reply(err)
    if redir
      res.redirect(redir.url, next)
    else 
      res.redirect("#{baseUrl}", next)
      # res.redirect("#{baseUrl}/views/404.html", next) # Code: 404
  )
)

# SERVER INIT

mongoose.connection
.on( 'error', console.error.bind(console, 'connection error:' ) )
.once( 'open', ()-> 
    server.listen( port )
    console.log('%s listening at %s', server.name, server.url);
)