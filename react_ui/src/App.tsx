import './App.css'
import '@aws-amplify/ui/dist/style.css'

import { ApolloProvider } from '@apollo/react-hooks'
import Amplify, { Auth } from 'aws-amplify'
import { Authenticator } from 'aws-amplify-react'
import React, { Suspense, useEffect, useState } from 'react'

import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
} from 'react-router-dom'

import { client } from './apollo/client'
import PrivateRoute from './auth/PrivateRoute'
import { RedirectAfterAuth } from './auth/RedirectAfterAuth'
import { AuthenticationState } from './auth/types'
import amplifyConfig from './aws-exports'
import { Footer } from './components/layout/Footer'
import { NavBar } from './components/layout/NavBar'
import { Chapter } from './pages/Chapter'
import { ChapterList } from './pages/ChapterList'
import { ChapterNew } from './pages/ChapterNew'
import StyleGuide from './pages/StyleGuide'

Amplify.configure(amplifyConfig)

const SecretComponent = () => <p>Secret!</p>

const App: React.FunctionComponent = () => {
  const [authState, setAuthState] = useState<AuthenticationState>('unknown')

  useEffect(() => {
    Auth.currentAuthenticatedUser()
      .then(() => setAuthState('authenticated'))
      .catch(() => setAuthState('anonymous'))
  }, [])

  if (authState === 'unknown') {
    return null
  }

  return (
    <ApolloProvider client={client}>
      <Suspense fallback="Loading...">
        <Router>
          <NavBar
            authState={authState}
            onSignOut={() => {
              Auth.signOut()
                .then(() => {
                  window.location.pathname = '/'
                })
                .catch((error) => {
                  // Woot?!
                  console.error(error)
                })
            }}
          />

          {authState === 'authenticated' && <RedirectAfterAuth />}

          <Switch>
            <Route path="/sign-in">
              <Authenticator
                onStateChange={(state) => {
                  const newState: AuthenticationState =
                    state === 'signedIn' ? 'authenticated' : 'anonymous'
                  setAuthState(newState)
                }}
              />
            </Route>

            <PrivateRoute
              exact
              path="/secret"
              isSignedIn={authState === 'authenticated'}
              component={SecretComponent}
            />

            <Route exact path="/chapters">
              <ChapterList />
            </Route>

            <Route exact path="/style-guide">
              <StyleGuide />
            </Route>

            <Route exact path="/chapters/new">
              <ChapterNew />
            </Route>

            <Route
              exact
              path="/:slug"
              render={({ match }) => <Chapter slug={match.params.slug} />}
            />

            <Route exact path="/">
              <Redirect to="/chapters" />
            </Route>
          </Switch>
          <Footer />
        </Router>
      </Suspense>
    </ApolloProvider>
  )
}

export default App
