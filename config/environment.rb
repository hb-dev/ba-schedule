# Load the rails application
require File.expand_path('../application', __FILE__)

$KCODE = 'u'
# Initialize the rails application
BaSchedule::Application.initialize!
$KCODE = 'u'