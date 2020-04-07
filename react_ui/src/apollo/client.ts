import { CognitoUser } from 'amazon-cognito-identity-js'
import ApolloClient from 'apollo-boost'
import Amplify, { Auth } from 'aws-amplify'

import amplifyConfig from '../aws-exports'

Amplify.configure(amplifyConfig)

export const client = new ApolloClient({
  uri: '/api/graphiql',
  request: (operation) => {
    return Auth.currentAuthenticatedUser()
      .then((user: CognitoUser) => {
        const token = user
          .getSignInUserSession()
          ?.getAccessToken()
          .getJwtToken()

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
