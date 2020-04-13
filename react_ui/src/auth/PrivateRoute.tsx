import * as React from 'react'
import { Redirect, Route, RouteProps } from 'react-router-dom'

import { AuthenticationState } from './types'

interface PrivateRouteProps extends RouteProps {
  authState: AuthenticationState
}

const PrivateRoute = (props: PrivateRouteProps) => {
  const { render, authState, ...rest } = props

  return (
    <Route
      {...rest}
      render={(routeProps) =>
        authState === 'authenticated' && render ? (
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
