import { ISignUpResult } from 'amazon-cognito-identity-js'
import Amplify, { Auth } from 'aws-amplify'
import {
  Authenticator,
  ConfirmSignUp,
  ForgotPassword,
  SignIn,
  VerifyContact,
} from 'aws-amplify-react'
import { Button } from 'aws-amplify-react'
import React from 'react'

import { AuthenticationState } from '../auth/types'
import amplifyConfig from '../aws-exports'
import { Input } from '../components/Input'

Amplify.configure(amplifyConfig)

interface SignUpProps {
  onStateChange?: (eventName: string, payload: ISignUpResult | {}) => void
  authState?: string
  override: string
}

const CustomSignUp: React.FunctionComponent<SignUpProps> = ({
  onStateChange,
  authState,
}) => {
  const [username, setUsername] = React.useState('')
  const [password, setPassword] = React.useState('')

  if (authState !== 'signUp' || !onStateChange) {
    return null
  }
  return (
    <>
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-3xl leading-9 font-extrabold text-gray-900">
          Sign in to your account
        </h2>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <form
            onSubmit={(event) => {
              event.preventDefault()
              Auth.signUp(username, password)
                .then((data) => {
                  return onStateChange('confirmSignUp', data)
                })
                // eslint-disable-next-line no-console
                .catch((err) => console.log(err))
            }}>
            <Input
              id="email"
              type="email"
              title="Email address"
              onChange={(event) => setUsername(event.currentTarget.value)}
            />
            <Input
              id="password"
              type="password"
              title="Password"
              onChange={(event) => setPassword(event.currentTarget.value)}
            />

            <div className="mt-6">
              <Button>Sign Up</Button>
            </div>
          </form>
        </div>

        <div className="mt-5">
          Already have an account?
          <Button
            onClick={() => {
              onStateChange('signIn', {})
            }}>
            Sign in
          </Button>
        </div>
      </div>
    </>
  )
}

const AuthenticatorWrapper: React.FunctionComponent<{
  setAuthState: (newState: AuthenticationState) => void
}> = ({ setAuthState }) => (
  <Authenticator
    hideDefault
    onStateChange={(state) => {
      const newState: AuthenticationState =
        state === 'signedIn' ? 'authenticated' : 'anonymous'
      setAuthState(newState)
    }}>
    <SignIn />
    <ForgotPassword />
    <VerifyContact />
    <ConfirmSignUp />
    <CustomSignUp override="SignUp"></CustomSignUp>
  </Authenticator>
)

export default AuthenticatorWrapper
