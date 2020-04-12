import './App.css'
import '@aws-amplify/ui/dist/style.css'

import { ApolloProvider } from '@apollo/client'
import React, { Suspense, useEffect, useState } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
} from 'react-router-dom'

import { Auth } from './amplify'
import { client } from './apollo/client'
import PrivateRoute from './auth/PrivateRoute'
import { RedirectAfterAuth } from './auth/RedirectAfterAuth'
import { AuthenticationState } from './auth/types'
import { Footer } from './components/layout/Footer'
import { NavBar } from './components/layout/NavBar'
import { SubNav } from './components/layout/SubNav'
import AuthenticatorWrapper from './pages/Authenticator'
import { Chapter } from './pages/Chapter'
import { ChapterEdit } from './pages/ChapterEdit'
import { ChapterList } from './pages/ChapterList'
import { ChapterNew } from './pages/ChapterNew'
import StyleGuide from './pages/StyleGuide'

const SecretComponent = () => <p>Secret!</p>

const App: React.FunctionComponent = () => {
  const [authState, setAuthState] = useState<AuthenticationState>('unknown')

  useEffect(() => {
    Auth.currentAuthenticatedUser()
      .then(() => setAuthState('authenticated'))
      .catch(() => setAuthState('anonymous'))
  }, [])

  if (authState === 'unknown') {
    return <div>Loading...</div>
  }

  return (
    <ApolloProvider client={client}>
      <Suspense fallback="Loading...">
        <Router>
          <NavBar />
          <SubNav />

          <main className="flex-grow">
            {authState === 'authenticated' && <RedirectAfterAuth />}

            <Switch>
              <Route path="/sign-in">
                <AuthenticatorWrapper setAuthState={setAuthState} />
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

              <Route
                exact
                path="/:slug/edit"
                render={({ match }) => <ChapterEdit slug={match.params.slug} />}
              />

              <Route exact path="/">
                <Redirect to="/chapters" />
              </Route>
            </Switch>
          </main>
          <Footer />
        </Router>
      </Suspense>
    </ApolloProvider>
  )
}

export default App
