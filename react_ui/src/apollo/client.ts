import ApolloClient from 'apollo-boost'

export const client = new ApolloClient({
  uri: '/api/graphiql',
})

export const getClient = (authToken?: string) => {
  return new ApolloClient({
    uri: '/api/graphiql',
    request: (operation) => {
      operation.setContext({
        headers: {
          authorization: authToken ? `Bearer ${authToken}` : '',
        },
      })
    },
  })
}
