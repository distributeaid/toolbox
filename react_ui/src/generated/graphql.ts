/* eslint-disable */
// This file was automatically generated and should not be edited.
// --
import gql from 'graphql-tag';
import * as ApolloReactCommon from '@apollo/react-common';
import * as ApolloReactHooks from '@apollo/react-hooks';
export type Maybe<T> = T | null;
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
};

export type Group = {
  readonly __typename?: 'Group';
  readonly description: Maybe<Scalars['String']>;
  readonly id: Maybe<Scalars['ID']>;
  readonly name: Maybe<Scalars['String']>;
};

export type RootMutationType = {
  readonly __typename?: 'RootMutationType';
  readonly createGroup: Maybe<Group>;
  readonly deleteGroup: Maybe<Group>;
  readonly updateGroup: Maybe<Group>;
};


export type RootMutationTypeCreateGroupArgs = {
  description: Maybe<Scalars['String']>;
  name: Scalars['String'];
};


export type RootMutationTypeDeleteGroupArgs = {
  id: Scalars['ID'];
};


export type RootMutationTypeUpdateGroupArgs = {
  description: Maybe<Scalars['String']>;
  id: Scalars['ID'];
};

export type RootQueryType = {
  readonly __typename?: 'RootQueryType';
  readonly countGroups: Maybe<Scalars['Int']>;
  readonly group: Maybe<Group>;
  readonly groups: Maybe<ReadonlyArray<Maybe<Group>>>;
  readonly healthCheck: Maybe<Scalars['String']>;
};


export type RootQueryTypeGroupArgs = {
  id: Scalars['ID'];
};

export type GetChapterListQueryVariables = {};


export type GetChapterListQuery = { readonly __typename?: 'RootQueryType', readonly groups: Maybe<ReadonlyArray<Maybe<{ readonly __typename?: 'Group', readonly id: Maybe<string>, readonly description: Maybe<string>, readonly name: Maybe<string> }>>> };


export const GetChapterListDocument = gql`
    query getChapterList {
  groups {
    id
    description
    name
  }
}
    `;

/**
 * __useGetChapterListQuery__
 *
 * To run a query within a React component, call `useGetChapterListQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetChapterListQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetChapterListQuery({
 *   variables: {
 *   },
 * });
 */
export function useGetChapterListQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetChapterListQuery, GetChapterListQueryVariables>) {
        return ApolloReactHooks.useQuery<GetChapterListQuery, GetChapterListQueryVariables>(GetChapterListDocument, baseOptions);
      }
export function useGetChapterListLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetChapterListQuery, GetChapterListQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetChapterListQuery, GetChapterListQueryVariables>(GetChapterListDocument, baseOptions);
        }
export type GetChapterListQueryHookResult = ReturnType<typeof useGetChapterListQuery>;
export type GetChapterListLazyQueryHookResult = ReturnType<typeof useGetChapterListLazyQuery>;
export type GetChapterListQueryResult = ApolloReactCommon.QueryResult<GetChapterListQuery, GetChapterListQueryVariables>;


