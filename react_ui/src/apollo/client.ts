import { CognitoUserSession } from 'amazon-cognito-identity-js'
import {
  ApolloClient,
  HttpLink,
  InMemoryCache,
  ApolloLink,
  fromPromise,
} from '@apollo/client'
import Amplify, { Auth } from 'aws-amplify'

import amplifyConfig from '../aws-exports'

Amplify.configure(amplifyConfig)

const httpLink = new HttpLink({
  uri: '/api',
  credentials: 'same-origin',
  fetch,
})

const authLink = new ApolloLink((operation, forward) => {
  return fromPromise(Auth.currentSession()
    .then((session: CognitoUserSession) => {
      const token = session.getAccessToken().getJwtToken()

      operation.setContext({
        headers: {
          authorization: token ? `Bearer ${token}` : '',
        },
      })

      return operation
    })
    .catch(() => {
      // not signed in
      return operation
    })
  ).flatMap(forward)
})

export const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: ApolloLink.from([authLink.concat(httpLink)]),
})
