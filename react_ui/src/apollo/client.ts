import {
  ApolloClient,
  ApolloLink,
  fromPromise,
  HttpLink,
  InMemoryCache,
} from '@apollo/client'
import { useAuth0 } from '@auth0/auth0-react'

const httpLink = new HttpLink({
  uri: '/api',
  credentials: 'same-origin',
  fetch,
})

const authLink = new ApolloLink((operation, forward) => {
  const { getAccessTokenSilently } = useAuth0()

  return fromPromise(
    getAccessTokenSilently()
      .then((token: string) => {
        operation.setContext({
          headers: {
            authorization: token ? `Bearer ${token}` : '',
          },
        })

        console.log(token)

        return operation
      })
      .catch(() => {
        // not signed in
        return operation
      })
  ).flatMap(forward)
})

export const client = new ApolloClient({
  cache: new InMemoryCache({
    typePolicies: {
      Group: {
        keyFields: ['slug'],
      },
    },
  }),
  link: ApolloLink.from([authLink.concat(httpLink)]),
})
