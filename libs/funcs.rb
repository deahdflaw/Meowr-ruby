function isLogged() do
  if request.cookies == nil
    return false
  else
    return true
  end
end