import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;

import jssc.SerialPort;
import jssc.SerialPortException;
import jssc.SerialPortTimeoutException;

public class devConnector 
{
        public static int TIMEOUT = 1000;
        
        public final int EXTERNAL =0;
        public final int INTERNAL = 0b10000000;
        
        public final int SETMODE = 22;
        public final int SET_GEN_FREQ = 31;
        public final int SET_GEN_AMP = 30;
        public final int SET_INF_FREQ = 32;
        public final int SET_INF_AMP = 33;
        
        public final int AM_MODE = 1;
        public final int FM_MODE = 2;
        public final int PM_MODE = 3;
        public final int SMH     = 5;
        
	private SerialPort port;
        
	private static byte[] pack(int i, int j)
	{
		byte[] result = new byte[4];
		result[0] = (byte)(150);
		result[1] = (byte) i;
		result[2] = (byte) j;
		result[3] = (byte)(result[0] ^ result[1] ^ result[2]);
		return result;
	}
	
	private void writeHeader() throws SerialPortException, SerialPortTimeoutException
	{
		byte[] answ;
                int count=0;
		do{	
			port.writeByte((byte) 150);
			answ = port.readBytes(1,TIMEOUT);
                        System.out.print(Byte.toUnsignedInt(answ[0])+";");
                        count ++;
                        if(count > 100) throw new SerialPortTimeoutException("Header was not sent after 100 tries","",100);
		}while(answ[0] !=1);
	}
	
	public devConnector(String portName) throws SerialPortException
	{
		port= new SerialPort(portName);
		port.openPort();
		port.setParams(SerialPort.BAUDRATE_9600, SerialPort.DATABITS_8,
				SerialPort.STOPBITS_2, SerialPort.PARITY_NONE);
	}
	
	public byte[] sendCmd(int cmd, int param) throws SerialPortException, SerialPortTimeoutException
	{
		byte[] answ = null;
		byte[] b = pack(cmd, param);
		writeHeader();
		for(int i=1; i<4;i++)
		{
			port.writeByte(b[i]);
			answ = port.readBytes(1,TIMEOUT);
			System.out.print(Arrays.toString(answ));	
		}
		System.out.println("");
                return answ;
	}
	
	public boolean closePort()
	{
            
		if(port.isOpened())
		{
                    try {
                        return port.closePort();
                    } catch (SerialPortException ex) {
                        Logger.getLogger(devConnector.class.getName()).log(Level.SEVERE, null, ex);
                        return false;
                    }
		}
                return true;
	}
	
	protected void finalize()
	{
		if(port.isOpened())
			try {
				port.closePort();
			} catch (SerialPortException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
                               
			}
	}
}
