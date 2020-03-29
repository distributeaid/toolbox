import React from "react";
import "./App.css";

import { BrowserRouter as Router, Switch, Route, Link } from "react-router-dom";
import SignUp from "./pages/SignUp";
import { GroupList } from './pages/GroupList'
import { Group } from "./pages/Group";

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
            <Link to="/groups">Group list</Link>
          </li>
        </ul>
      </nav>
      <Switch>
        <Route path="/groups/:id" render={({ match }) => <Group id={match.params.id} />} />
        <Route path="/groups">
          <GroupList />
        </Route>
        <Route path="/sign-up">
          <SignUp />
        </Route>
        <Route path="/">
          <Home />
        </Route>
      </Switch>
    </Router>
  );
};

const Home = () => <div>Welcome Home</div>;

export default App;
