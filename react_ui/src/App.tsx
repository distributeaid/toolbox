import './App.css'
import '@aws-amplify/ui/dist/style.css'

import { ApolloProvider } from '@apollo/client'
import React, { Suspense } from 'react'
import { Helmet } from 'react-helmet'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
} from 'react-router-dom'

import { client } from './apollo/client'
import PrivateRoute from './auth/PrivateRoute'
import { RedirectAfterAuth } from './auth/RedirectAfterAuth'
import { useAuthState } from './auth/useAuthState'
import { Footer } from './components/layout/Footer'
import { NavBar } from './components/layout/NavBar'
import { SubNav } from './components/layout/SubNav'
import ogImage from './og/image.png'
import AuthenticatorWrapper from './pages/Authenticator'
import { Chapter } from './pages/Chapter'
import { ChapterEdit } from './pages/ChapterEdit'
import { ChapterList } from './pages/ChapterList'
import { ChapterNew } from './pages/ChapterNew'
import StyleGuide from './pages/StyleGuide'
import ScrollToTop from './util/scrollToTop'

const App: React.FunctionComponent = () => {
  const { authState, setAuthState } = useAuthState()

  return (
    <ApolloProvider client={client}>
      <Helmet>
        <meta property="og:site_name" content="Masks For Docs"></meta>
        <meta property="og:title" content="Masks For Docs"></meta>
        <meta
          property="og:image"
          content={[process.env.PUBLIC_URL, ogImage].join('')}
        />
      </Helmet>
      <Suspense fallback="Loading...">
        <Router>
          <ScrollToTop />
          <NavBar />
          <SubNav />

          <main className="flex-grow">
            {authState === 'authenticated' && <RedirectAfterAuth />}

            <Switch>
              <Route path="/sign-in">
                <AuthenticatorWrapper setAuthState={setAuthState} />
              </Route>

              <Route exact path="/chapters">
                <ChapterList />
              </Route>

              <Route exact path="/style-guide">
                <StyleGuide />
              </Route>

              <PrivateRoute
                authState={authState}
                exact
                path="/chapters/new"
                render={() => <ChapterNew />}
              />

              <Route
                exact
                path="/:slug"
                render={({ match }) => <Chapter slug={match.params.slug} />}
              />

              <PrivateRoute
                authState={authState}
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
