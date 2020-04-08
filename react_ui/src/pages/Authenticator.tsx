import Amplify from 'aws-amplify'
import { Authenticator, UsernameAttributes } from 'aws-amplify-react'
import React from 'react'

import { AuthenticationState } from '../auth/types'
import amplifyConfig from '../aws-exports'

Amplify.configure(amplifyConfig)

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
