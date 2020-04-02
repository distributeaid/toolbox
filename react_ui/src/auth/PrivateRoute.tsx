import * as React from 'react'
import { Route, Redirect, RouteProps } from 'react-router-dom'
import { useLocation } from 'react-router-dom'

interface PrivateRouteProps extends RouteProps {
  component: any
  isSignedIn: boolean
}

const PrivateRoute = (props: PrivateRouteProps) => {
  const { component: Component, isSignedIn, ...rest } = props

  const location = useLocation()

  return (
    <Route
      {...rest}
      render={(routeProps) =>
        isSignedIn ? (
          <Component {...routeProps} />
        ) : (
          <Redirect
            to={{
              pathname: `/auth?redirect=${location.pathname}${location.search}`,
              state: { from: routeProps.location },
            }}
          />
        )
      }
    />
  )
}

export default PrivateRoute
