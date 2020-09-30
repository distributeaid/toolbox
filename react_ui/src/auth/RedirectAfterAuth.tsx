import React from 'react'
import { Redirect, useLocation } from 'react-router-dom'

export const RedirectAfterAuth = () => {
  const location = useLocation<{ redirectAfterAuth?: Location }>()

  const redirect = location.state && location.state.redirectAfterAuth

  if (location.pathname !== '/sign-in') {
    return null
  }

  return <Redirect to={redirect || '/'} />
}
