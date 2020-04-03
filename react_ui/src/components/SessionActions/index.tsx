import React, { useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useGetSessionLazyQuery } from '../../generated/graphql'
import { Button } from '../Button'
import Amplify, { Auth } from 'aws-amplify'
import amplifyConfig from '../../aws-exports'

Amplify.configure(amplifyConfig)

interface Props {
  setAuthToken: React.Dispatch<React.SetStateAction<string | undefined>>
  authToken?: string
}

export const SessionActions: React.FunctionComponent<Props> = ({
  setAuthToken,
  authToken,
}) => {
  // const { data } = useGetSessionQuery()
  const [loadSession, { data }] = useGetSessionLazyQuery()

  useEffect(() => {
    loadSession()
  }, [authToken])

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
            .then((data) => {
              setAuthToken(undefined)
            })
            // eslint-disable-next-line no-console
            .catch((err) => console.log('signed out error', err))
        }}>
        Sign out
      </Button>
    </div>
  )
}
