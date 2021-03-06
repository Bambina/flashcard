require 'spec_helper'

RSpec.describe WordsController, :type => :controller do
	describe 'guest access' do
		before :each do
			@user = create(:user)
			@word = create(:word, user: @user)
		end

		describe 'GET #new' do
			it 'requires login' do
				get :new
				expect(response).to require_login
			end
		end

		describe 'GET #edit' do
			it 'requires login' do
				get :edit, id: @word
				expect(response).to require_login
			end
		end

		describe 'POST #create' do
			it 'requires login' do
				post :create,
				id: @word,
				word: attributes_for(:word)
				expect(response).to require_login
			end
		end

		describe 'PUT #update' do
			it 'requires login' do
				put :update,
				id: @word,
				word: attributes_for(:word)
				expect(response).to require_login
			end
		end

		describe 'DELETE #destroy' do
			it 'requires login' do
				delete :destroy,
				id: @word
				expect(response).to require_login
			end
		end
	end

	describe 'login user access' do
		before :each do
			@user = create(:user)
			login_user(@user)
		end

		describe 'GET #index' do
			it 'populates an array of words having login_user_id' do
				word1     = create(:word, user: @user)
				word2     = create(:word, user: @user, name: 'walk')
				word3     = create(:word)
				sentence1 = create(:sentence, word: word1)
				sentence2 = create(:sentence, word: word2, content: 'take a walk')
				get :index
				expect( assigns(:words).count ).to eq 3 #including auto generated word(banana)
			end

			it 'renders the :inedx template' do
				get :index
				expect( response ).to render_template :index
			end
		end

		describe 'GET #index with search query' do
			it 'populates an array of words having search query' do
				word1     = create(:word, user: @user, name: 'work')
				word2     = create(:word, user: @user, name: 'walk')
				sentence1 = create(:sentence, word: word1, content: 'allow to work')
				sentence2 = create(:sentence, word: word2, content: 'take a walk')
				get :index, {:search => 'al'}
				expect( assigns(:words) ).to match_array [word1, word2]
			end

			it 'renders the :inedx template' do
				get :index, {:search => 'al'}
				expect( response ).to render_template :index
			end
		end

		describe 'GET #index with pagination' do
			it 'populates an array of first 10 words' do
				word_list = ['the','museum','will','house','server',
							 'host','first','ever','website','in','London']
				word_list.each_with_index do |word,i|
					eval("@word#{i} = create(:word, user: @user, name: word)")
					eval("@sentence#{i} = create(:sentence, word: @word#{i}, content: #{i})")
				end
				get :index
				## array ordered by 'created_at DESC' ##
				expect( assigns(:words) ).to match_array [@word1,@word2,@word3,@word4,@word5,
														  @word6,@word7,@word8,@word9,@word10]
			end
		end

		describe 'GET #show' do
			it 'assigns the requested word to @word' do
				word = create(:word, user: @user)
				get :show, id: word
				expect( assigns(:word) ).to eq word
			end

			it 'assigns @word which has a login_user_id' do
				word = create(:word, user: @user)
				get :show, id: word
				expect( assigns(:word).user_id ).to eq @user.id
			end

			it 'does not assign @word which was made by an another user' do
				@user2 = create(:user)
				word = create(:word, user: @user2)
				get :show, id: word
				expect( assigns(:word) ).to eq nil
			end

			it 'renders the :show template' do
				word = create(:word, user: @user)
				get :show, id: word
				expect( response ).to render_template :show
			end
		end

		describe 'GET #new' do
			it 'assigns a new Word to @word' do
				get :new
				expect( assigns(:word) ).to be_a_new(Word)
			end

			it 'renders the :new template' do
				get :new
				expect( response ).to render_template :new
			end
		end

		describe 'GET #edit' do
			it 'assigns the requested word to @word' do
				word = create(:word, user: @user)
				get :edit, id: word
				expect( assigns(:word) ).to eq word
			end

			it 'assigns @word having login_user_id' do
				word = create(:word, user: @user)
				get :edit, id: word
				expect( assigns(:word).user_id ).to eq @user.id
			end

			it 'does not assign @word which was made by an another user' do
				word = create(:word)
				get :edit, id: word
				expect( assigns(:word) ).to eq nil
			end

			it 'renders the :edit template' do
				word = create(:word, user: @user)
				get :edit, id: word
				expect( response ).to render_template :edit
			end
		end

		describe 'POST #create' do
			before :each do
				@sentences = [
					attributes_for(:sentence),
					attributes_for(:sentence, content: 'I must work up my science for the test.')]
			end

			context 'with valid attribute' do
				it 'saves a new word in the database' do
					expect{
						post :create,
						word: attributes_for(:word, user: @user, sentences_attributes: @sentences)
						}.to change(Word, :count).by(1)
				end

				it 'redireccts to words#show' do
					post :create,
					word: attributes_for(:word, user: @user, sentences_attributes: @sentences)
					expect( response ).to redirect_to word_path(assigns[:word])
				end
			end

			context 'with invalid attributes' do
				it 'does not save the new word in the database' do
					expect{
						post :create,
						word: attributes_for(:invalid_word)
					}.to_not change(Word, :count)
				end

				it 'renders the new template if the new word is not saved' do
					post :create,
					word: attributes_for(:invalid_word)
					expect( response ).to render_template :new
				end
			end
		end

		describe 'PUT #update' do
			before :each do
				@word = create(
					:word,
					user: @user)
			end
			context 'with valid attributes' do
				it 'locates requested @word' do
					put :update,
					id: @word,
					word: attributes_for(:word)
					expect(assigns(:word)).to eq @word
				end

				it "changes @word's attributes" do
					new_name = 'well'
					new_word_type = 'adverb'
					put :update,
					id: @word,
					word: attributes_for(:word, name: new_name, word_type: new_word_type)
					@word.reload
					expect(@word.name).to eq new_name
					expect(@word.word_type).to eq new_word_type
				end

				it 'redirects to the updated word' do
					put :update, id: @word, word: attributes_for(:word)
					expect(response).to redirect_to @word
				end
			end

			context 'with invalid attributes'  do
				it 'does not change the attributes' do
					put :update,
					id: @word,
					word: attributes_for(:word, name: 'well', word_type: nil)
					@word.reload
					expect(@word.name).to_not eq 'well'
					expect(@word.word_type).to eq 'noun'
				end

				it 're-renders the edit template' do
					put :update,
					id: @word,
					word: attributes_for(:invalid_word)
					expect(response).to render_template :edit
				end
			end
		end

		describe 'DELETE #destroy' do
			before :each do
				@word = create(
					:word,
					user: @user)
			end

			context 'with valid attributes' do
				it 'deletes the word' do
					expect{
						delete :destroy,
						id: @word
					}.to change(Word, :count).by -1
				end

				it 'redirects words index' do
					delete :destroy,
					id: @word
					expect(response).to redirect_to words_path
				end
			end
		end
	end
end
