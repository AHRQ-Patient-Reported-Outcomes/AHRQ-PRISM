'use strict'

require('dotenv').config()
const app = require('./app')

const port = process.env.PORT || 3031
app.listen(port, () =>
  console.log(`Server is listening on port ${port}.`)
)
