import { CognitoUserSession } from 'amazon-cognito-identity-js'
import ApolloClient from 'apollo-boost'
import Amplify, { Auth } from 'aws-amplify'

import amplifyConfig from '../aws-exports'

Amplify.configure(amplifyConfig)

export const client = new ApolloClient({
  uri: '/api',
  request: (operation) => {
    return Auth.currentSession()
      .then((session: CognitoUserSession) => {
        const token = session.getAccessToken().getJwtToken()

        operation.setContext({
          headers: {
            authorization: token ? `Bearer ${token}` : '',
          },
        })
      })
      .catch(() => {
        // not signed in
      })
  },
})
