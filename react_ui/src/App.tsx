import React from "react";
import "./App.css";

import { BrowserRouter as Router, Switch, Route, Link } from "react-router-dom";
import SignUp from "./pages/SignUp";
import { ChapterList } from './pages/ChapterList'
import { Chapter } from "./pages/Chapter";

const App: React.FunctionComponent = () => {
  return (
    <Router>
      <nav>
        <ul>
          <li>
            <Link to="/">Home</Link>
          </li>
          <li>
            <Link to="/sign-up">Sign up</Link>
          </li>
          <li>
            <Link to="/chapters">Group list</Link>
          </li>
        </ul>
      </nav>
      <Switch>
        <Route path="/chapters">
          <ChapterList />
        </Route>
        <Route path="/sign-up">
          <SignUp />
        </Route>
        <Route path="/:slug" render={({ match }) => <Chapter slug={match.params.slug} />} />
        <Route path="/">
          <Home />
        </Route>
      </Switch>
    </Router>
  );
};

const Home = () => <div>Welcome Home</div>;

export default App;
