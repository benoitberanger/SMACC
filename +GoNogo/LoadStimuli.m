Stimuli = struct;


% %% Audio files
% % Stimuli.Audio.(filename) = audiosignal;
% 
% audio_content = dir([DataStruct.Parameters.Path.wav '*.wav']);
% audio_name = {audio_content.name}';
% audio_name = strrep(audio_name,'.wav','');
% 
% for a = 1 : length(audio_content)
%     Stimuli.Audio.(audio_name{a}) = wavread( [DataStruct.Parameters.Path.wav audio_name{a} '.wav'] );
% end


%% Image files
% Stimuli.Image.(filename) = texturePointer;

contexts = fieldnames(DataStruct.Parameters.Path);

for c = 1:length(contexts)
    
    img_content = dir([DataStruct.Parameters.Path.(contexts{c}) filesep '*.bmp']);
    img_name = {img_content.name}';
    img_name = strrep(img_name,'.bmp','');
    
    for i = 1 : length(img_content)
        current_img = imread([DataStruct.Parameters.Path.(contexts{c}) filesep img_name{i} '.bmp']);
        Stimuli.(contexts{c}).([contexts{c} '_' img_name{i}]) = Screen( 'MakeTexture' , DataStruct.PTB.wPtr , current_img );
    end
    
end
