import React from "react";
import { Auth } from "aws-amplify";
import { Button } from "../components/Button";
import { Input } from "../components/Input";
import { Checkbox } from "../components/Checkbox";
import { Divider } from "../components/Divider";

import Amplify from "aws-amplify";
import amplifyConfig from "../aws-exports";

Amplify.configure(amplifyConfig);

const SignUp = () => {
  const [username, setUsername] = React.useState("");
  const [password, setPassword] = React.useState("");
  return (
    <>
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <h2 className="mt-6 text-center text-3xl leading-9 font-extrabold text-gray-900">
            Sign in to your account
          </h2>
        </div>

        <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
          <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
            <form
              onSubmit={event => {
                event.preventDefault();
                Auth.signIn(username, password)
                  .then(user => console.log(user))
                  .catch(err => console.log(err));
              }}
            >
              <Input
                id="email"
                type="email"
                title="Email address"
                onChange={event => setUsername(event.currentTarget.value)}
              />
              <Input
                id="password"
                type="password"
                title="Password"
                onChange={event => setPassword(event.currentTarget.value)}
              />

              <div className="mt-6 flex items-center justify-between">
                <Checkbox title="Remember me" id="remember_me" />

                <div className="text-sm leading-5">
                  <a
                    href="#"
                    className="font-medium text-indigo-600 hover:text-indigo-500 focus:outline-none focus:underline transition ease-in-out duration-150"
                  >
                    Forgot your password?
                  </a>
                </div>
              </div>

              <div className="mt-6">
                <Button title="Sign in" />
              </div>
            </form>

            <div className="mt-6">
              <Divider>Or</Divider>
            </div>

            <form
              onSubmit={event => {
                event.preventDefault();
                Auth.signUp(username, password)
                  .then(user => console.log(user))
                  .catch(err => console.log(err));
              }}
            >
              <Input
                id="email"
                type="email"
                title="Email address"
                onChange={event => setUsername(event.currentTarget.value)}
              />
              <Input
                id="password"
                type="password"
                title="Password"
                onChange={event => setPassword(event.currentTarget.value)}
              />

              <div className="mt-6">
                <Button title="Sign up" />
              </div>
            </form>
          </div>
        </div>
        <ConfirmEmail></ConfirmEmail>
      </div>
      <div>{username}</div>
      <div>{password}</div>
    </>
  );
};

const ConfirmEmail = () => {
  const [username, setUsername] = React.useState("");
  const [verificationCode, setVerificationCode] = React.useState("");
  return (
    <div>
      Verify with code from email
      <form
        onSubmit={event => {
          event.preventDefault();
          Auth.confirmSignUp(username, verificationCode)
            .then(user => console.log(user))
            .catch(err => console.log(err));
        }}
      >
        <div className="grid">
          <label>
            Email
            <input
              className="border"
              name="username"
              onChange={event => setUsername(event.currentTarget.value)}
            ></input>
          </label>
          <label>
            Verification code (check email)
            <input
              className="border"
              onChange={event => setVerificationCode(event.currentTarget.value)}
              type="text"
              name="verification-code"
            ></input>
          </label>

          <input type="submit" value="Verify" />
        </div>
      </form>
    </div>
  );
};

export default SignUp;
