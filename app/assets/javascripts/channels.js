var App = App || {};
App.cable = ActionCable.createConsumer();

$(document).on('turbolinks:load', function() {
  App.cable.subscriptions.subscriptions.forEach(s => s.unsubscribe());
});

$(document).on('turbolinks:load', function() {
  if ($('.questions').length !== 0)
    App.cable.subscriptions.create('QuestionsChannel', {
      connected: function () {
        console.log('Connected to QuestionsChannel');
      },
      received: function(data) {
        console.log(data);
        $('.questions').append(JST["templates/question"]({ question: data.question })).find('.gist').each(loadGist);
      }
    });
});

$(document).on('turbolinks:load', function() {
  if (gon.question_id != null)
    App.cable.subscriptions.create({ channel: 'AnswersChannel', question_id: gon.question_id }, {
      connected: function () {
        console.log(`Connected to AnswersChannel for Question ${ gon.question_id }`);
      },
      received: function(answer) {
        console.log(answer);
        $('.answers').append(JST["templates/answer"]({ answer: answer })).find('.gist').each(loadGist);
      }
    });
});

$(document).on('turbolinks:load', function() {
  if ($('.questions').length !== 0 || gon.question_id != null )
    App.cable.subscriptions.create({ channel: 'CommentsChannel', question_id: gon.question_id }, {
      connected: function () {
        console.log(`Connected to CommentsChannel`);
      },
      received: function(comment) {
        console.log(comment);
        $(`#${comment.ref} .comments`).append(JST["templates/comment"]({ comment: comment }));
      }
    });
});
