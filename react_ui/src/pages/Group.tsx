import React from "react";

type Country = {
  id: string;
  name: string;
};

type Group = {
  id: string;
  name: string;
  country: Country;
  members: number;
};

type Maybe<T> = T | null

const useGroup = (id: string): Maybe<Group> => {
  if (id === '1') {
    return {
      id: "1",
      name: "Group1",
      members: 23,
      country: {
        id: "1",
        name: "US"
      }
    }
  }

  if (id === '2') {
    return {
        id: '2',
        name: "Group2",
        members: 45,
        country: {
          id: '2',
          name: "US"
        }
      }
  }

  return null
}

type Props = {
  id: string;
};

export const Group: React.FC<Props> = ({ id }) => {
  const group = useGroup(id)

  if (!group) {
    return <div>Group {id} not found</div>
  }

  return <div>{group.name}</div>;
};
