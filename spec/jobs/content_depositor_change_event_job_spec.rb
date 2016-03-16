require 'spec_helper'

describe ContentDepositorChangeEventJob do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:third_user) { create(:user) }
  let(:file_set) { create(:file_set, title: ['Hamlet'], user: user) }
  let(:generic_work) { create(:generic_work, title: ['BethsMac'], user: user) }
  let(:mock_time) { Time.zone.at(1) }
  after do
    Redis.current.keys('events:*').each { |key| Redis.current.del key }
    Redis.current.keys('User:*').each { |key| Redis.current.del key }
    Redis.current.keys('FileSet:*').each { |key| Redis.current.del key }
    Redis.current.keys('GenericWork:*').each { |key| Redis.current.del key }
  end

  it "logs the event to the proxy depositor's profile, the depositor's dashboard, followers' dashboards, and the FileSet" do
    third_user.follow(another_user)
    allow_any_instance_of(User).to receive(:can?).and_return(true)
    event = { action: "User <a href=\"/users/#{user.to_param}\">#{user.user_key}</a> has transferred <a href=\"/concern/generic_works/#{generic_work.id}\">BethsMac</a> to user <a href=\"/users/#{another_user.to_param}\">#{another_user.user_key}</a>", timestamp: '1' }
    allow(Time).to receive(:now).at_least(:once).and_return(mock_time)
    described_class.perform_now(generic_work.id, another_user.user_key)
    expect(user.profile_events.length).to eq(1)
    expect(user.profile_events.first).to eq(event)
    expect(another_user.events.length).to eq(1)
    expect(another_user.events.first).to eq(event)
    expect(third_user.events.length).to eq(1)
    expect(third_user.events.first).to eq(event)
    expect(generic_work.events.length).to eq(1)
    expect(generic_work.events.first).to eq(event)
  end
end
