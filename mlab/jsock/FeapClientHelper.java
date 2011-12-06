import java.net.*;
import java.io.*;
import java.nio.*;
import java.util.regex.*;

public class FeapClientHelper {

    private Process process;
    private Socket socket;
    private DataInputStream in;
    private DataOutputStream out;

    public FeapClientHelper(String hostname, int port) 
        throws IOException {
        socket = new Socket(hostname, port);
        in = new DataInputStream(socket.getInputStream());
        out = new DataOutputStream(socket.getOutputStream());
    }

    public FeapClientHelper(String cmd) 
        throws IOException {
        process = Runtime.getRuntime().exec(cmd);
        in = new DataInputStream(process.getInputStream());
        out = new DataOutputStream(process.getOutputStream());
    }

    public void close() 
        throws IOException {
        out.close();
        in.close();
        if (socket != null)
            socket.close();
        if (process != null)
            process.destroy();
    }

    public String readln()
        throws IOException {

        StringBuffer buf = new StringBuffer();
        char c;
        do {
            c = (char) in.readByte();
            if (c != '\n')
                buf.append(c);
        } while (c != '\n');
        return buf.toString();
    }

    public void send(String s) 
        throws IOException {
        out.writeBytes(s);
        out.writeByte('\n');
        out.flush();
    }

    public double[] getDarray(int size) 
	throws IOException {
        double[] darray = new double[size];
	for (int j = 0; j < size; ++j)
	    darray[j] = in.readDouble();
        return darray;
    }

    public int[] getIarray(int size) 
	throws IOException {
        int[] iarray = new int[size];
	for (int j = 0; j < size; ++j)
	    iarray[j] = in.readInt();
        return iarray;
    }

    public void setIarray(double[] x) 
        throws IOException {
        int size = x.length;
        for (int j = 0; j < size; ++j)
            out.writeInt((int) x[j]);
        out.flush();
    }

    public void setDarray(double[] x) 
        throws IOException {
        int size = x.length;
        for (int j = 0; j < size; ++j)
            out.writeDouble(x[j]);
        out.flush();
    }

}

