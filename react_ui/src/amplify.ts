import Amplify, { Auth } from 'aws-amplify'

const productionConfig = {
  aws_project_region: 'us-east-2',
  aws_cognito_region: 'us-east-2',
  aws_user_pools_id: 'us-east-2_UXyIsmbAj',
  aws_user_pools_web_client_id: '1f651oo55hfbtghvi25kve14hp',
  oauth: {},
}

// NOTE: for development, production config is overwritten by .env.development
const amplifyConfig = !process.env.REACT_APP_AWS_USER_POOLS_ID
  ? productionConfig
  : {
      aws_project_region: process.env.REACT_APP_AWS_PROJECT_REGION,
      aws_cognito_region: process.env.REACT_APP_AWS_COGNITO_REGION,
      aws_user_pools_id: process.env.REACT_APP_AWS_USER_POOLS_ID,
      aws_user_pools_web_client_id:
        process.env.REACT_APP_AWS_USER_POOLS_WEB_CLIENT_ID,
      oauth: {},
    }

Amplify.configure(amplifyConfig)

export { Auth }
