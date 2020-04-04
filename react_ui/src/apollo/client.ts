import ApolloClient from 'apollo-boost'

export const client = new ApolloClient({
  uri: '/api/graphiql',
  request: (operation) => {
    const authToken = JSON.parse(localStorage.getItem('authToken') || 'null')
    operation.setContext({
      headers: {
        authorization: authToken ? `Bearer ${authToken}` : '',
      },
    })
  },
})
