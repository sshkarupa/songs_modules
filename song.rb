class Song
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :lyrics,       Text
  property :length,       Integer
  property :released_on,  Date
  property :likes,        Integer, default: 0

  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

DataMapper.finalize

module SongHelpers
  def find_songs
    @songs = Song.all
  end

  def find_song
    @song = Song.get(params[:id])
  end

  def create_song
    @song = Song.create(params[:song])
  end
end

class SongController < ApplicationController
  helpers SongHelpers

  get '/' do
    find_songs
    slim :songs
  end

  get '/new' do
    protected!
    @song = Song.new
    slim :new_song
  end

  post '/' do
    flash[:notice] = "Song successfully added" if create_song
    redirect to("/#{@song.id}")
  end

  get '/:id' do
    find_song
    slim :show_song
  end

  get '/:id/edit' do
    protected!
    find_song
    slim :edit_song
  end

  put '/:id' do
    find_song
    flash[:notice] = "Song successfully updated" if @song.update(params[:song])
    redirect to("/#{@song.id}")
  end

  delete '/:id' do
    protected!
    flash[:notice] = "Song deleted" if find_song.destroy
    redirect to('/')
  end

  post '/:id/like' do
    @song = find_song
    @song.likes = @song.likes.next
    @song.save
    redirect to("/#{@song.id}") unless request.xhr?
    slim :like, layout: false
  end
end
