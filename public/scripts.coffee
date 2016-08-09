form   = document.getElementById('shorten-form')
urlBox = form.elements[0]
link   = document.getElementById('link')
shrBox = document.getElementById('shortened')


displayShortenedUrl = (response) ->
  if response.data.error
    return alertError(response.data.error)
  console.log "response", response
  link.textContent = response.data.shortUrl
  link.setAttribute 'href', response.data.shortUrl
  shrBox.style.opacity = '1'
  urlBox.value = ''
  # Reset input
  return

# End of function to update the view
# Callback function passed to Axios' error handler

alertError = (error) ->
  # Handle server or validation errors
  console.log error
  alert 'Error: Are you sure the URL is correct? Make sure it has http:// at the beginning.' 
  return

form.addEventListener 'submit', (event) ->
  event.preventDefault()
  # Send the POST request to the backend  
  axios.post('/new', url: urlBox.value).then(displayShortenedUrl).catch alertError
  return
