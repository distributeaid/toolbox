import React from 'react'
import { Link } from 'react-router-dom'
import { useGetSessionQuery } from '../../generated/graphql'
import { Button } from '../Button'
import Amplify, { Auth } from 'aws-amplify'
import amplifyConfig from '../../aws-exports'

Amplify.configure(amplifyConfig)

export const SessionActions: React.FunctionComponent = () => {
  const { data } = useGetSessionQuery()

  const userId = data?.session?.userId

  if (!userId) {
    return <Link to="/sign-up">Sign up / Sign in</Link>
  }

  return (
    <div className="flex">
      <div>Welcome, {userId}</div>
      <Button
        moreClassNames="ml-auto"
        onClick={() => {
          Auth.signOut({ global: true })
            // eslint-disable-next-line no-console
            .then((data) => console.log('signed out', data))
            // eslint-disable-next-line no-console
            .catch((err) => console.log('signed out error', err))
        }}>
        Sign out
      </Button>
    </div>
  )
}
