import './App.css'
import '@aws-amplify/ui/dist/style.css'

import { ApolloProvider } from '@apollo/client'
import { useAuth0 } from '@auth0/auth0-react'
import React, { Suspense } from 'react'
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom'

import { client } from './apollo/client'
import PrivateRoute from './auth/PrivateRoute'
import { Footer } from './components/layout/Footer'
import { NavBar } from './components/layout/NavBar'
import { Chapter } from './pages/Chapter'
import { ChapterEdit } from './pages/ChapterEdit'
import { ChapterList } from './pages/ChapterList'
import { ChapterNew } from './pages/ChapterNew'
import { Home } from './pages/Home'
import StyleGuide from './pages/StyleGuide'
import ScrollToTop from './util/scrollToTop'

const App: React.FunctionComponent = () => {
  const { isAuthenticated, isLoading } = useAuth0()

  if (isLoading) {
    return <div>Loading...</div>
  }

  return (
    <ApolloProvider client={client}>
      <Suspense fallback="Loading...">
        <Router>
          <ScrollToTop />
          <NavBar />

          <main className="flex-grow">
            <Switch>
              <Route exact path="/chapters">
                <ChapterList />
              </Route>

              <Route exact path="/style-guide">
                <StyleGuide />
              </Route>

              <PrivateRoute
                isAuthenticated={isAuthenticated}
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
                isAuthenticated={isAuthenticated}
                exact
                path="/:slug/edit"
                render={({ match }) => <ChapterEdit slug={match.params.slug} />}
              />

              <Route exact path="/">
                <Home />
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
