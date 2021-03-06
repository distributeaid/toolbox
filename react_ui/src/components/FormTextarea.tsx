import { Field, FieldProps } from 'formik'
import React from 'react'

import { FormErrorMessage } from './FormErrorMessage'

type Props = {
  name: string
  title: string
}

export const FormTextarea: React.FC<Props> = ({ name, title }) => {
  return (
    <Field name={name}>
      {({ field }: FieldProps) => {
        return (
          <div>
            <label
              htmlFor={name}
              className="block text-sm font-medium leading-5 text-gray-700">
              {title}
            </label>
            <textarea
              {...field}
              id={name}
              className="w-full h-40 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm"
            />
            <FormErrorMessage name={name} />
          </div>
        )
      }}
    </Field>
  )
}
