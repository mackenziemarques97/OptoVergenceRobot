classdef ExperimentClass_GUI_LEDboard < handle %define handle class
        
    properties %define properties of the handle class
        connection %serial connection
    end
    
    methods %define methods of the handle class (functions to use)
                %% Experiment Constructor
        % constructor method to create an instance of the class
        % ExperimentClass_master
        
        %comPort is "COM#" from USB serial connection; AKA serial port
        function obj = ExperimentClass_master(serialPort) 
            %creates serial port object associated with the serial port
            obj.connection = serial(serialPort); 
            %next 4 lines characterize communication port connection
            set(obj.connection,'DataBits',8); 
            set(obj.connection,'StopBits',1);
            set(obj.connection,'BaudRate',9600);
            set(obj.connection,'Parity','none');
            set(obj.connection,'Timeout',60);
            
            %start serial connection/open serial port object
            fopen(obj.connection);
        end
        
        %% sendPhaseParams
        function sendPhaseParams(obj,dir,color,deg,timeOn)
            str1 = sprintf('sendPhaseParams:%s:%s:',[dir,color]);
            str2 = sprintf('%d:%d:',[deg,timeOn]);
            sendInfo = [str1 str2];       
            fprintf(obj.connection, sendInfo); 
        end
        
        %% showLEDs
        function showLEDs(obj)            
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,'showLEDs:'); 
        end
        
   end
end
