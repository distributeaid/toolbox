import * as React from 'react'
import { Redirect, Route, RouteProps } from 'react-router-dom'

interface PrivateRouteProps extends RouteProps {
  isSignedIn: boolean
}

const PrivateRoute = (props: PrivateRouteProps) => {
  const { component: Component, isSignedIn, ...rest } = props

  return (
    <Route
      {...rest}
      render={(routeProps) =>
        isSignedIn && Component ? (
          <Component {...routeProps} />
        ) : (
          <Redirect
            to={{
              pathname: '/sign-in',
              state: { redirectAfterAuth: routeProps.location },
            }}
          />
        )
      }
    />
  )
}

export default PrivateRoute
