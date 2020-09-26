import { Authenticator, UsernameAttributes } from 'aws-amplify-react'
import React from 'react'

import { AuthenticationState } from '../auth/types'

const AuthenticatorWrapper: React.FunctionComponent<{
  setAuthState: (newState: AuthenticationState) => void
}> = ({ setAuthState }) => (
  <Authenticator
    signUpConfig={{
      hiddenDefaults: [UsernameAttributes.PHONE_NUMBER],
    }}
    usernameAttributes={UsernameAttributes.EMAIL}
    onStateChange={(state) => {
      const newState: AuthenticationState =
        state === 'signedIn' ? 'authenticated' : 'anonymous'
      setAuthState(newState)
    }}
  />
)

export default AuthenticatorWrapper
