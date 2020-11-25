import * as React from 'react'
import {
  Redirect,
  Route,
  RouteComponentProps,
  RouteProps,
} from 'react-router-dom'

interface PrivateRouteProps extends RouteProps {
  isAuthenticated: boolean
  // NOTE: make render required for this Route
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  render: (props: RouteComponentProps<any>) => React.ReactNode
}

const PrivateRoute = (props: PrivateRouteProps) => {
  const { render, isAuthenticated, ...rest } = props

  return (
    <Route
      {...rest}
      render={(routeProps) =>
        isAuthenticated ? (
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
