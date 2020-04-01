import React from "react";
import "./App.css";

import { BrowserRouter as Router, Switch, Route, Link, Redirect } from "react-router-dom";
import SignUp from "./pages/SignUp";
import { ChapterList } from './pages/ChapterList'
import { Chapter } from "./pages/Chapter";
import StyleGuide from "./pages/StyleGuide";

const App: React.FunctionComponent = () => {
  return (
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

        <Route exact path="/:slug" render={({ match }) => <Chapter slug={match.params.slug} />} />

        <Route exact path="/">
          <Redirect to="/chapters" />
        </Route>
      </Switch>
    </Router>
  );
};

export default App;
