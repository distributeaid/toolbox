import './index.css'
import './i18n'

import { Auth0Provider } from '@auth0/auth0-react'
import React from 'react'
import ReactDOM from 'react-dom'

import App from './App'

ReactDOM.render(
  <React.StrictMode>
    <Auth0Provider
      domain="distributeaid.eu.auth0.com"
      clientId="3wxYeItzvD1fN5tloBikUHED8sQ1BImj"
      redirectUri={window.location.origin}>
      <App />
    </Auth0Provider>
  </React.StrictMode>,
  document.getElementById('root')
)
