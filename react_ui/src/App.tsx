import './App.css'

import { ApolloProvider } from '@apollo/react-hooks'
import React from 'react'
import {
  BrowserRouter as Router,
  Link,
  Redirect,
  Route,
  Switch,
} from 'react-router-dom'

import { client } from './apollo/client'
import { Chapter } from './pages/Chapter'
import { ChapterList } from './pages/ChapterList'
import SignUp from './pages/SignUp'
import StyleGuide from './pages/StyleGuide'

const App: React.FunctionComponent = () => {
  return (
    <ApolloProvider client={client}>
      <Router>
        <nav>
          <ul>
            <li>
              <Link to="/sign-up">Sign up</Link>
            </li>

            <li>
              <Link to="/style-guide">Style guide</Link>
            </li>
          </ul>
        </nav>

        <Switch>
          <Route exact path="/chapters">
            <ChapterList />
          </Route>

          <Route exact path="/sign-up">
            <SignUp />
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
    </ApolloProvider>
  )
}

export default App
