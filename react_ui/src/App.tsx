import './App.css'
import '@aws-amplify/ui/dist/style.css'

import React, { Suspense, useState, useEffect } from 'react'
import { ApolloProvider } from '@apollo/react-hooks'
import {
  BrowserRouter as Router,
  Link,
  Redirect,
  Route,
  Switch,
} from 'react-router-dom'
import Amplify, { Auth } from 'aws-amplify'
import amplifyConfig from './aws-exports'
import { Authenticator } from 'aws-amplify-react'

import { client } from './apollo/client'
import { Chapter } from './pages/Chapter'
import { ChapterList } from './pages/ChapterList'
import StyleGuide from './pages/StyleGuide'
import PrivateRoute from './auth/PrivateRoute'
import { RedirectAfterAuth } from './auth/RedirectAfterAuth'

Amplify.configure(amplifyConfig)

type AuthenticationState = 'unknown' | 'authenticated' | 'anonymous'

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
          <nav className="mb-4 shadow">
            <ul>
              <li>
                <Link to="/">Home</Link>
              </li>
              {authState === 'anonymous' && (
                <li>
                  <Link to="/sign-in">Sign up / Sign in</Link>
                </li>
              )}
              {authState === 'authenticated' && (
                <li>
                  <button
                    type="button"
                    onClick={() => {
                      Auth.signOut()
                        .then(() => {
                          window.location.pathname = '/'
                        })
                        .catch((error) => {
                          // Woot?!
                          console.error(error)
                        })
                    }}>
                    Log out
                  </button>
                </li>
              )}

              <li>
                <Link to="/style-guide">Style guide</Link>
              </li>

              {authState === 'authenticated' && (
                <li>
                  <Link to="/secret">Page behind login</Link>
                </li>
              )}
            </ul>
          </nav>

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

            <Route
              exact
              path="/:slug"
              render={({ match }) => <Chapter slug={match.params.slug} />}
            />

            <Route exact path="/">
              <Redirect to="/chapters" />
            </Route>
          </Switch>
        </Router>
      </Suspense>
    </ApolloProvider>
  )
}

export default App
