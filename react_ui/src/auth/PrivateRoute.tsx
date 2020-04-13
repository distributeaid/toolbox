import * as React from 'react'
import { Redirect, Route, RouteProps } from 'react-router-dom'

interface PrivateRouteProps extends RouteProps {
  isSignedIn: boolean
}

const PrivateRoute = (props: PrivateRouteProps) => {
  const { render, isSignedIn, ...rest } = props

  return (
    <Route
      {...rest}
      render={(routeProps) =>
        isSignedIn && render ? (
          render(routeProps)
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
