"""
    Text to visualze attention map for.
"""
# encode the string
d = self.input_vocab.string_to_int(text)

# get the output sequence
predicted_text = run_example(
    self.pred_model, self.input_vocab, self.output_vocab, text)

text_ = list(text) + ['<eot>'] + ['<unk>'] * self.input_vocab.padding
# get the lengths of the string
input_length = len(text) + 1
output_length = predicted_text.index('<eot>') + 1
# get the activation map
activation_map = np.squeeze(self.proba_model.predict(np.array([d])))[
                 0:output_length, 0:input_length]

# import seaborn as sns
plt.clf()
f = plt.figure(figsize=(8, 8.5))
ax = f.add_subplot(1, 1, 1)

# add image
i = ax.imshow(activation_map, interpolation='nearest', cmap='gray')

# add colorbar
cbaxes = f.add_axes([0.2, 0, 0.6, 0.03])
cbar = f.colorbar(i, cax=cbaxes, orientation='horizontal')
cbar.ax.set_xlabel('Probability', labelpad=2)

# add labels
ax.set_yticks(range(output_length))
ax.set_yticklabels(predicted_text[:output_length])

ax.set_xticks(range(input_length))
ax.set_xticklabels(text_[:input_length], rotation=45)

ax.set_xlabel('Input Sequence')
ax.set_ylabel('Output Sequence')

# add grid and legend
ax.grid()
# ax.legend(loc='best')

f.savefig(os.path.join(HERE, 'attention_maps', text.replace('/', '') + '.pdf'), bbox_inches='tight')
f.show()