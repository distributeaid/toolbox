#!/usr/bin/env bash

# Adding data to database for development
# Start by adding a value to the group table

set -ex

psql \
    -d $POSTGRES_DB \
    -U $POSTGRES_USER \
    -c "INSERT INTO groups (name, slug, type, slack_channel_name, request_form, request_form_results, volunteer_form, volunteer_form_results, donation_form, donation_form_results, description, inserted_at, updated_at)
    VALUES ('group1', 'group1', 'M4D_CHAPTER', 'slack-channel-name', 'request_form', 'request_form_results', 'volunteer_form', 'volunteer_form_results', 'donation_form', 'donation_form_results', 'this group helps developers test', '2019-02-18 08:35:06', '2019-02-18 08:35:06');"

psql_exit_status=$?

if [ $psql_exit_status != 0 ]; then
    echo "psql failed while trying to insert test group" 1>&2
    exit $psql_exit_status
fi

echo "test group creation successful"

exit 0
