import ApolloClient from 'apollo-boost'
import Amplify, { Auth } from 'aws-amplify'
import amplifyConfig from '../aws-exports'
import { CognitoUser } from 'amazon-cognito-identity-js'

Amplify.configure(amplifyConfig)

export const client = new ApolloClient({
  uri: '/api/graphiql',
  // request: async (operation) => {
  //   let user: CognitoUser | undefined = undefined
  //   try {
  //     user = await Auth.currentAuthenticatedUser()
  //   } catch {
  //     // not signed in
  //   }
  //   if (!user) {
  //     return
  //   }

  //   const token = user.getSignInUserSession()?.getAccessToken().getJwtToken()

  //   operation.setContext({
  //     headers: {
  //       authorization: token ? `Bearer ${token}` : '',
  //     },
  //   })
  // },
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
