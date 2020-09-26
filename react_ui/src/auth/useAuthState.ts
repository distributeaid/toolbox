import { Auth } from 'aws-amplify'
import { useEffect, useState } from 'react'

import { AuthenticationState } from './types'

export const useAuthState = () => {
  const [authState, setAuthState] = useState<AuthenticationState>('unknown')

  useEffect(() => {
    Auth.currentAuthenticatedUser()
      .then(() => setAuthState('authenticated'))
      .catch(() => setAuthState('anonymous'))
  }, [])

  const signOut = () =>
    Auth.signOut()
      .then(() => {
        window.location.pathname = '/'
      })
      .catch((error) => {
        // Woot?!
        console.error(error)
      })

  return { authState, setAuthState, signOut }
}
