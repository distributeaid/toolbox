import './App.css'
import '@aws-amplify/ui/dist/style.css'

import React, { Suspense, useState } from 'react'
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

const SecretComponent = () => <p>Secret!</p>

const App: React.FunctionComponent = () => {
  const [isSignedIn, setSignedIn] = useState<boolean>(false)
  return (
    <ApolloProvider client={client}>
      <Suspense fallback="Loading...">
        <Router>
          <nav>
            <ul>
              {!isSignedIn && (
                <li>
                  <Link to="/auth">Sign up</Link>
                </li>
              )}
              {isSignedIn && (
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
            </ul>
          </nav>

          <RedirectAfterAuth isSignedIn={isSignedIn} />

          <Switch>
            <Route path="/auth">
              <Authenticator
                onStateChange={(state) => {
                  const isSignedIn = state === 'signedIn'
                  setSignedIn(isSignedIn)
                }}
              />
            </Route>

            <PrivateRoute
              exact
              path="/secret"
              isSignedIn={isSignedIn}
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
