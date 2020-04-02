import React from 'react'
import { Redirect, useLocation } from 'react-router-dom'

export const RedirectAfterAuth = ({ isSignedIn }: { isSignedIn: boolean }) => {
  const location = useLocation()
  if (!isSignedIn) return null
  const redirect = new URLSearchParams(location.search).get('redirect')
  if (!redirect) return null
  return <Redirect to={redirect} />
}
