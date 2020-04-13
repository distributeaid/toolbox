import { ErrorMessage } from 'formik'
import React from 'react'

export const FormErrorMessage: React.FC<{ name: string }> = ({ name }) => (
  <ErrorMessage name={name}>
    {(msg) => <span className="text-red-600 text-sm -mt-2">{msg}</span>}
  </ErrorMessage>
)
